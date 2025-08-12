import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../supabase_client.dart';
import '../widgets/components.dart';

class CertificationsPage extends StatefulWidget {
  const CertificationsPage({Key? key}) : super(key: key);

  @override
  State<CertificationsPage> createState() => _CertificationsPageState();
}

class _CertificationsPageState extends State<CertificationsPage> {
  late Future<List<Map<String, dynamic>>> _certificationsFuture;

  @override
  void initState() {
    super.initState();
    _certificationsFuture = _fetchCertifications();
  }

  Future<List<Map<String, dynamic>>> _fetchCertifications() async {
    try {
      final response = await supabase
          .from('certificates')
          .select()
          .order('issue_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load certifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle("Certifications"),
            const SizedBox(height: 24),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _certificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState();
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message:
                        "Failed to load certifications. Please try again later.",
                    onRetry: () => setState(() =>
                        _certificationsFuture = _fetchCertifications()),
                  );
                }

                final certs = snapshot.data ?? [];

                if (certs.isEmpty) {
                  return const EmptyState(
                    message: "No certifications to display yet.",
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: certs.length,
                  itemBuilder: (context, index) {
                    final cert = certs[index];
                    return CertificateCard(
                      name: cert['name'] ?? '',
                      authority: cert['authority'] ?? '',
                      description: cert['description'],
                      issueDate: cert['issue_date'] != null
                          ? DateTime.parse(cert['issue_date'])
                          : null,
                      expiryDate: cert['expiry_date'] != null
                          ? DateTime.parse(cert['expiry_date'])
                          : null,
                      credentialId: cert['credential_id'],
                      credentialUrl: cert['credential_url'],
                      fileUrl: cert['file_url'],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final String name;
  final String authority;
  final String? description;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? fileUrl;

  const CertificateCard({
    Key? key,
    required this.name,
    required this.authority,
    this.description,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.fileUrl,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('MMM yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final hasFileUrl = fileUrl != null && fileUrl!.isNotEmpty;
    final certificateFileUrl = hasFileUrl
        ? (fileUrl!.startsWith('http')
            ? fileUrl!
            : '$storageUrl/certificates/$fileUrl')
        : null;

    final hasCredentialUrl = credentialUrl != null && credentialUrl!.isNotEmpty;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 24),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: certificateFileUrl != null
            ? () {
                html.window.open(certificateFileUrl, 'Certificate');
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Text(
                          authority,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (certificateFileUrl != null)
                    IconButton(
                      icon: const Icon(Icons.file_open),
                      color:
                          Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        html.window.open(
                            certificateFileUrl, 'Certificate');
                      },
                      tooltip: 'View Certificate',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (issueDate != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Issued: ${_formatDate(issueDate)}${expiryDate != null ? ' • Expires: ${_formatDate(expiryDate)}' : ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
              if (credentialId != null && credentialId!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Credential ID: $credentialId',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  description!,
                  style: TextStyle(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
              if (hasCredentialUrl) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify Credential'),
                  onPressed: () {
                    launchUrl(Uri.parse(credentialUrl!));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }
}